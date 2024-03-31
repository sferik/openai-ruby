require_relative "../test_helper"

module OpenAI
  class VersionTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil VERSION
    end

    def test_segments_array
      assert_kind_of Array, VERSION.segments
    end

    def test_major_version_integer
      assert_kind_of Integer, VERSION.segments[0]
    end

    def test_minor_version_integer
      assert_kind_of Integer, VERSION.segments[1]
    end

    def test_patch_version_integer
      assert_kind_of Integer, VERSION.segments[2]
    end

    def test_to_s
      assert_kind_of String, VERSION.to_s
    end
  end
end
