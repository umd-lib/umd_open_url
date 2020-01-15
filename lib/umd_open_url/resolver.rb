# frozen_string_literal: true

require 'faraday'
require 'rack'

module UmdOpenUrl
  # Queries the OpenUrl resolver service, returning links to the resource,
  # if available.
  class Resolver
    # Returns a list of URLs as provided by the OpenURL resolver server, or an
    # empty list if no results are found, or an error occurs.
    def self.resolve(open_url)
      json = query(open_url)
      links = parse_response(json)
      links
    end

    # Performs the network request, returning a JSON object
    def self.query(open_url)
      return nil if open_url.nil?

      # Perform a HTTP GET request to the WorldCat OpenUrl Resolver
      response = Faraday.get(open_url)

      # Return nil if response is not succesful
      return nil unless response.status == 200

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        nil
      end
    end

    # Parses the given JSON object, returning a list of links, or an empty
    # list if there are no results, or an error occurs
    def self.parse_response(json) # rubocop:disable Metrics/AbcSize,  Metrics/MethodLength
      filtered_linker_urls = []

      return filtered_linker_urls if json.nil?

      # Find the items with a non-empty "linkerurl" parameter
      jsons_with_linkerurl = json.select { |j| !j['linkerurl'].nil? && !j['linkerurl'].empty? }
      return filtered_linker_urls unless jsons_with_linkerurl

      jsons_with_linkerurl.each do |j|
        linkerurl = j['linkerurl']
        linkerurl_uri = URI.parse(linkerurl)
        next unless linkerurl_uri.query

        params_map = CGI.parse(linkerurl_uri.query)

        # Strip out the "wskey" parameter, as it should not be included in the
        # link that is sent to the client browser.
        filtered_params_map = params_map.reject { |k, _v| k == 'wskey' }

        # Regenerate the query parameters string. Using Rack::Utils.build_query
        # because it produces a query string without array-based parameters
        filtered_params = Rack::Utils.build_query(filtered_params_map)

        filtered_params = nil if filtered_params.strip.empty?

        # Construct the link to the resource
        filtered_linkerurl_uri = URI::HTTP.build(
          host: linkerurl_uri.host,
          path: linkerurl_uri.path,
          query: filtered_params
        )

        filtered_linkerurl_uri.scheme = linkerurl_uri.scheme
        filtered_linker_url = filtered_linkerurl_uri.to_s

        filtered_linker_urls << filtered_linker_url
      end

      UmdOpenUrl.logger.debug(
        "UmdOpenUrl::Builder.build - parse_response: Found #{filtered_linker_urls.size} linkerurls."
      )
      filtered_linker_urls
    end
  end
end
