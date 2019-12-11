# frozen_string_literal: true

require 'test_helper'

class TestResolver < Minitest::Test
  def test_resolver_with_non_json_response
    stub_request(:get, 'http://example.com/non_json_response')
      .to_return(body: 'Hello world')
    json_response = UmdOpenUrl::Resolver.resolve('http://example.com/non_json_response')
    assert_nil json_response
  end

  def test_resolver_with_empty_response
    stub_request(:get, 'http://example.com/empty_response')
      .to_return(body: '')
    json_response = UmdOpenUrl::Resolver.resolve('http://example.com/empty_response')
    assert_nil json_response
  end

  def test_resolver_with_404_response
    stub_request(:get, 'http://example.com/404_response')
      .to_return(body: '', status: 404)
    json_response = UmdOpenUrl::Resolver.resolve('http://example.com/404_response')
    assert_nil json_response
  end

  def test_resolver_with_empty_json_response
    stub_request(:get, 'http://example.com/empty_json_response').to_return(body: '{}')
    json_response = UmdOpenUrl::Resolver.resolve('http://example.com/empty_json_response')
    assert_equal Hash.new, json_response # rubocop:disable Style/EmptyLiteral
  end

  def test_resolver_with_invalid_json_response
    stub_request(:get, 'http://example.com/invalid_json_response').to_return(body: '{')
    json_response = UmdOpenUrl::Resolver.resolve('http://example.com/invalid_json_response')
    assert_nil json_response
  end

  def test_resolver_with_invalid_linkerurl_response
    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org/"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_nil link
  end

  def test_parser_with_nil
    link = UmdOpenUrl::Resolver.parse_response(nil)
    assert_nil link
  end

  def test_parser_with_empty_json
    json = JSON.parse('{}')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_nil link
  end

  def test_parser_with_invalid_linkerurl_response
    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org/"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_nil link
  end

  def test_parser_with_valid_linkerurl_response
    # linkerurl should have query parameters
    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?foo=abc"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org?foo=abc', link
  end

  def test_wskey_filtering # rubocop:disable Metrics/AbcSize
    # linkerurl should have query parameters
    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?foo=abc&wskey=123"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org?foo=abc', link

    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?wskey=123&foo=abc"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org?foo=abc', link

    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?wskey=123&foo=abc"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org?foo=abc', link

    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?bar=456&wskey=123&foo=abc"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org?bar=456&foo=abc', link

    json = JSON.parse('[{"linkerurl": "http://link.worldcat.org?wskey=123"}]')
    link = UmdOpenUrl::Resolver.parse_response(json)
    assert_equal 'http://link.worldcat.org', link
  end
end
