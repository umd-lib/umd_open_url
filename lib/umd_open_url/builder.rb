# frozen_string_literal: true

module UmdOpenUrl
  # Builder for fluently creating an OpenUrl with particular parameters
  class Builder
    def initialize(resolver_url)
      @resolver_url = resolver_url
      @params_map = {}
    end

    def issn(issn)
      @params_map['rft.issn'] = issn
      self
    end

    def volume(volume)
      @params_map['rft.volume'] = volume
      self
    end

    def start_page(start_page)
      @params_map['rft.spage'] = start_page
      self
    end

    def publication_date(publication_date)
      @params_map['rft.date'] = publication_date
      self
    end

    def custom_param(param_name, param_value)
      @params_map[param_name] = param_value
      self
    end

    # Returns a string representing the OpenURL hyperlink from the provided
    # parameters
    def build
      params = @params_map.map { |k, v| "#{k}=#{v}" }.join('&')
      @resolver_url + '?' + params
    end
  end
end
