# frozen_string_literal: true

require 'test_helper'

class TestResolver < Minitest::Test
  def test_resolver_with_non_json_response
    stub_request(:get, 'http://example.com/non_json_response')
      .to_return(body: 'Hello world')
    links = UmdOpenUrl::Resolver.resolve('http://example.com/non_json_response')
    assert links.empty?
  end

  def test_resolver_with_empty_response
    stub_request(:get, 'http://example.com/empty_response')
      .to_return(body: '')
    links = UmdOpenUrl::Resolver.resolve('http://example.com/empty_response')
    assert links.empty?
  end

  def test_resolver_with_404_response
    stub_request(:get, 'http://example.com/404_response')
      .to_return(body: '', status: 404)
    links = UmdOpenUrl::Resolver.resolve('http://example.com/404_response')
    assert links.empty?
  end

  def test_resolver_with_empty_json_response
    stub_request(:get, 'http://example.com/empty_json_response').to_return(body: '{}')
    links = UmdOpenUrl::Resolver.resolve('http://example.com/empty_json_response')
    assert links.empty?
  end

  def test_resolver_with_invalid_json_response
    stub_request(:get, 'http://example.com/invalid_json_response').to_return(body: '{')
    links = UmdOpenUrl::Resolver.resolve('http://example.com/invalid_json_response')
    assert links.empty?
  end

  def test_resolver_with_invalid_linkerurl_response
    stub_request(:get, 'http://example.com/invalid_linkerurl').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org/"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/invalid_linkerurl')
    assert links.empty?
  end

  def test_resolver_with_single_valid_linkerurl_response
    stub_request(:get, 'http://example.com/single_linkerurl').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?foo=abc"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/single_linkerurl')
    assert_equal 1, links.size
    assert_equal 'http://link.worldcat.org?foo=abc', links[0]
  end

  def test_resolver_with_multiple_valid_linkerurl_response
    stub_request(:get, 'http://example.com/multiple_linkerurl').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?foo=abc"}, {"linkerurl": "http://link.worldcat.org?bar=cde"} ]'
    )

    links = UmdOpenUrl::Resolver.resolve('http://example.com/multiple_linkerurl')
    assert_equal 2, links.size
    assert_equal 'http://link.worldcat.org?foo=abc', links[0]
    assert_equal 'http://link.worldcat.org?bar=cde', links[1]
  end

  def test_wskey_filtering # rubocop:disable Metrics/AbcSize
    # wskey parameter should not be included in links

    # wskey at end
    stub_request(:get, 'http://example.com/wskey_filtering').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?foo=abc&wskey=123"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/wskey_filtering')
    assert_equal 'http://link.worldcat.org?foo=abc', links[0]

    # wskey at beginning
    stub_request(:get, 'http://example.com/wskey_filtering').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?wskey=123&foo=abc"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/wskey_filtering')
    assert_equal 'http://link.worldcat.org?foo=abc', links[0]

    # wskey in middle
    stub_request(:get, 'http://example.com/wskey_filtering').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?bar=456&wskey=123&foo=abc"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/wskey_filtering')
    assert_equal 'http://link.worldcat.org?bar=456&foo=abc', links[0]

    # wskey as only parameter
    stub_request(:get, 'http://example.com/wskey_filtering').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?wskey=123"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/wskey_filtering')
    assert_equal 'http://link.worldcat.org', links[0]

    # No wskey parameter
    stub_request(:get, 'http://example.com/wskey_filtering').to_return(
      body: '[{"linkerurl": "http://link.worldcat.org?foo=123"}]'
    )
    links = UmdOpenUrl::Resolver.resolve('http://example.com/wskey_filtering')
    assert_equal 'http://link.worldcat.org?foo=123', links[0]
  end
end
