require "helper"

module Nokogiri
  module XML
    class TestNodeAttributes < Nokogiri::TestCase
      def test_attribute_with_ns
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert_equal 'bar',
          node.attribute_with_ns('foo', 'http://tenderlovemaking.com/').value
      end

      def test_prefixed_attributes
        doc = Nokogiri::XML "<root xml:lang='en-GB' />"

        node = doc.root

        assert_equal 'en-GB', node['xml:lang']
        assert_equal 'en-GB', node.attributes['lang'].value
        assert_equal nil, node['lang']
      end

      def test_set_prefixed_attributes
        doc = Nokogiri::XML %Q{<root xmlns:foo="x"/>}

        node = doc.root

        node['xml:lang'] = 'en-GB'
        node['foo:bar']  = 'bazz'

        assert_equal 'en-GB', node['xml:lang']
        assert_equal 'en-GB', node.attributes['lang'].value
        assert_equal nil, node['lang']
        assert_equal 'http://www.w3.org/XML/1998/namespace', node.attributes['lang'].namespace.href

        assert_equal 'bazz', node['foo:bar']
        assert_equal 'bazz', node.attributes['bar'].value
        assert_equal nil, node['bar']
        assert_equal 'x', node.attributes['bar'].namespace.href
      end

      def test_namespace_key?
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert node.namespaced_key?('foo', 'http://tenderlovemaking.com/')
        assert node.namespaced_key?('foo', nil)
        assert !node.namespaced_key?('foo', 'foo')
      end

      def test_set_attribute_frees_nodes # testing a segv
        skip("JRuby doesn't do GC.") if Nokogiri.jruby?
        document = Nokogiri::XML.parse("<foo></foo>")

        node = document.root
        node['visible'] = 'foo'
        attribute = node.attribute('visible')
        text = Nokogiri::XML::Text.new 'bar', document
        attribute.add_child(text)

        begin
          gc_previous = GC.stress
          GC.stress = true
          node['visible'] = 'attr'
        ensure
          GC.stress = gc_previous
        end
      end
    end
  end
end
