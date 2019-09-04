require 'test_helper'

class BenchmarkIdTest < ActiveSupport::TestCase
  test 'verify that a benchmark id can be created from string' do
    id1 = BenchmarkId.from_s '1.15'
    assert_equal 1, id1.capacity_id
    assert_equal 15, id1.indicator_id
    assert_equal '1.15', id1.to_s

    id2 = BenchmarkId.from_s '10.01'
    assert_equal 10, id2.capacity_id
    assert_equal 1, id2.indicator_id
    assert_equal '10.1', id2.to_s
  end

  test 'verify that benchmark ids are put in benchmark order' do
    id_list = [
      (BenchmarkId.from_s '2.5'),
      (BenchmarkId.from_s '1.15'),
      (BenchmarkId.from_s '11.10'),
      (BenchmarkId.from_s '11.1')
    ]
    sorted_list = [
      (BenchmarkId.from_s '1.15'),
      (BenchmarkId.from_s '2.5'),
      (BenchmarkId.from_s '11.1'),
      (BenchmarkId.from_s '11.10')
    ]

    res = id_list.sort

    assert_equal (BenchmarkId.from_s '2.5'), id_list[0]
    assert_equal sorted_list, res
  end
end
