# frozen_string_literal: true

require 'faraday'
require 'rack'

module UmdOpenUrl
  # Queries an OpenUrl, returning a direct link to the resource, if available.
  class Resolver
    def self.resolve(open_url)
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

    def self.parse_response(json) # rubocop:disable Metrics/AbcSize,  Metrics/MethodLength, Metrics/CyclomaticComplexity
      return nil if json.nil?

      # Find the items with a non-empty "linkerurl" parameter
      jsons_with_linkerurl = json.select { |j| !j['linkerurl'].nil? && !j['linkerurl'].empty? }
      return nil unless jsons_with_linkerurl

      filtered_linker_urls = []

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

      if filtered_linker_urls.empty?
        UmdOpenUrl.logger.debug('UmdOpenUrl::Builder.build - parse_response: No linkerurls found. Returning nil.')
        return nil
      end

      UmdOpenUrl.logger.debug(
        "UmdOpenUrl::Builder.build - parse_response: Found #{filtered_linker_urls.size} linkerurls."
      )
      filtered_linker_urls
    end
  end
end
