# frozen_string_literal: true

module UmdOpenUrl
  # Builder for fluently creating an OpenUrl with particular parameters.
  #
  # When passing parameter values, nil values will be ignored.
  class Builder
    def initialize(resolver_url)
      @resolver_url = resolver_url
      @params_map = {}
    end

    def issn(issn)
      @params_map[:issn] = issn unless issn.nil?
      self
    end

    def volume(volume)
      @params_map[:volume] = volume unless volume.nil?
      self
    end

    def issue(issue_number)
      @params_map[:issue] = issue_number unless issue_number.nil?
      self
    end

    def start_page(start_page)
      @params_map[:start_page] = start_page unless start_page.nil?
      self
    end

    def publication_date(publication_date)
      @params_map[:publication_date] = publication_date unless publication_date.nil?
      self
    end

    def custom_param(param_name, param_value)
      @params_map[param_name.to_sym] = param_value unless param_value.nil?
      self
    end

    # Returns true if the given parameters have been populated, false otherwise
    # List of parameters should be provided as symbols corresponding to the
    # parameter method names, or custom parameter name
    def valid?(required_params)
      required_params.each do |p|
        return false unless @params_map.key?(p)
      end
      true
    end

    # Returns a string representing the OpenURL hyperlink from the provided
    # parameters
    def build
      params = @params_map.map do |k, v|
        open_url_key = open_url_params_map[k] || k.to_s
        "#{open_url_key}=#{v}"
      end.join('&')
      open_url = @resolver_url + '?' + params
      UmdOpenUrl.logger.debug do
        # Filter out the wskey parameter value
        logged_url = open_url.sub(/wskey=.*?&/, 'wskey=###&')
        UmdOpenUrl.logger.debug("UmdOpenUrl::Builder.build - open_url: #{logged_url}")
      end
      open_url
    end

    private

    # Mapping of param names to OpenUrl query parameter names
    def open_url_params_map
      {
        issn: 'rft.issn',
        volume: 'rft.volume',
        issue: 'rft.issue',
        start_page: 'rft.spage',
        publication_date: 'rft.date'
      }
    end
  end
end
