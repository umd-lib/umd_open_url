# frozen_string_literal: true

require 'test_helper'

class TestBuilder < Minitest::Test
  def test_open_url_builder # rubocop:disable Metrics/AbcSize
    b = UmdOpenUrl::Builder.new('http://example.com')
    b.issn('1234-4567')
    b.volume(1)
    b.issue(4)
    b.start_page(64)
    b.publication_date('1988-01-24')
    b.custom_param('wskey', 'SECRET_KEY')
    url = b.build
    assert url.start_with?('http://example.com')
    assert url.include?('rft.volume=1')
    assert url.include?('rft.issue=4')
    assert url.include?('rft.spage=64')
    assert url.include?('rft.date=1988-01-24')
    assert url.include?('wskey=SECRET_KEY')
    assert url.include?('rft.issn=1234-4567')
  end

  def test_nil_values_should_be_ignored # rubocop:disable Metrics/AbcSize
    b = UmdOpenUrl::Builder.new('http://example.com')
    b.issn(nil)
    b.volume(nil)
    b.issue(nil)
    b.start_page(nil)
    b.publication_date(nil)
    b.custom_param('wskey', nil)
    url = b.build
    assert url.start_with?('http://example.com')
    assert !url.include?('rft.volume=1')
    assert !url.include?('rft.issue=4')
    assert !url.include?('rft.spage=64')
    assert !url.include?('rft.date=1988-01-24')
    assert !url.include?('wskey=SECRET_KEY')
    assert !url.include?('rft.issn=1234-4567')
  end

  def test_valid
    b = UmdOpenUrl::Builder.new('http://example.com')
    assert_equal false, b.valid?(%i[issn])
    b.issn('1234-4567')
    assert_equal true, b.valid?(%i[issn])
    assert_equal false, b.valid?(%i[issn volume])

    b.custom_param('wskey', 'SECRET_KEY')
    assert_equal true, b.valid?(%i[issn wskey])
    assert_equal false, b.valid?(%i[issn wskey volume])
  end
end
