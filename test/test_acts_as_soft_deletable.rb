require File.join(File.dirname(__FILE__), 'helper')

class TestActsAsSoftDeletable < SoftDeleteTestCase
  def test_destroy_should_create_a_deleted_model
    artist = Artist.find_by_name('Chick Corea')
    artist.destroy
    assert_nil Artist.find_by_name('Chick Corea')

    deleted = Artist::Deleted.find_by_name('Chick Corea')
    assert_soft_delete_models_are_equal artist, deleted
  end

  def test_destroy_should_set_deleted_at_timestamp
    artist = Artist.find_by_name('Chick Corea')
    artist.destroy

    deleted = Artist::Deleted.find_by_name('Chick Corea')
    assert deleted.deleted_at.between?(1.minute.ago, 1.minute.from_now)
  end

  def test_deleted_model_should_be_able_to_undestroy
    assert(deleted = Artist::Deleted.find_by_name('Robert Walter'))
    assert_nil Artist.find_by_name('Robert Walter')

    deleted.undestroy!

    assert_soft_delete_models_are_equal deleted, Artist.find_by_name('Robert Walter')
    assert_nil Artist::Deleted.find_by_name('Robert Walter')
    assert deleted.frozen?
  end

  def test_should_copy_decimals_correctly
    decimal = Decimal.find(1)
    assert_nil Decimal::Deleted.find_by_id(1)

    decimal.destroy
    deleted = Decimal::Deleted.find(1) 
    assert deleted.deleted_at.between?(1.minute.ago, 1.minute.from_now)

    deleted.undestroy!
    assert_soft_delete_models_are_equal deleted, Decimal.find(1) 
    assert deleted.frozen?
  end

  def test_helper_should_work
    assert_model_soft_deletes Artist.find_by_name('Chick Corea')
  end

  def test_should_replace_any_existing_deleted_entry
    assert (d = Decimal.find(38383))
    assert Decimal::Deleted.find(38383)

    assert_nothing_raised { d.destroy }
  end
end
