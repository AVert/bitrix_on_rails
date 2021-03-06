require 'helper'

class IblockElementTest < Test::Unit::TestCase

  context 'define_iblock_class' do
    setup do
      stub(iblock = Object.new).version { 2 }
      stub(Iblock).find { iblock }
    end

    context 'with class_name set to nil' do
      setup do
        BitrixOnRails.define_iblock_class(3)
      end

      teardown do
        Object.send :remove_const, "IblockElement3"
      end

      should 'create class IblockElement3 in global namespace' do
        assert_not_nil Object.const_defined?("IblockElement3")
      end
    end

    context 'with class name in global namespace' do
      setup do
        BitrixOnRails.define_iblock_class(3, :class_name => 'PostProperties')
      end

      should 'create class PostProperties in global namespace' do
        assert_not_nil Object.const_defined?('PostProperties')
      end
    end

    context 'with class name in non global namespace' do
      setup do
        Object.const_set('Post', Class.new)
        BitrixOnRails.define_iblock_class(3, :class_name => 'Post::Element')
      end

      should 'create class Element in Post namespace' do
        assert_not_nil Post.const_defined?('Element')
      end
    end

    context 'behaviour' do
      setup do
        BitrixOnRails.define_iblock_class(3)
      end

      teardown do
        Object.send :remove_const, "IblockElement3"
      end

      should 'create association with property classes' do
        assert_not_nil IblockElement3.reflections[:property_set]
        assert_not_nil IblockElement3.reflections[:m_props]
      end

      should 'create property classes' do
        assert_not_nil Object.const_defined?('IblockElementPropS3')
        assert_not_nil Object.const_defined?('IblockElementPropM3')
      end

      should 'create associations for property classes in IblockElement' do
        assert_not_nil IblockElement.reflections[:iblock_element_prop_s3]
        assert_not_nil IblockElement.reflections[:iblock_element_prop_m3]
      end

      should 'add class information in BitrixOnRails.infoblocks' do
        assert_equal IblockElement3, BitrixOnRails.infoblocks[3]
      end
    end

    context 'with passed :extended_by' do
      setup do
        Object.const_set('IblockElementExtension', Module.new{ def some_method ; end})
        BitrixOnRails.define_iblock_class(3, :extended_by => 'IblockElementExtension')
      end

      teardown do
        Object.send :remove_const, "IblockElement3"
      end

      should 'extend created class with given module' do
        # Не нашел другого способа проверить, что модуль был включен в класс
        assert IblockElement3.methods.include?(:some_method)
      end
    end

  end

  context 'described by iblock with version == 1' do
    setup do
      @iblock = Factory.create(:iblock_v1)
      @iblock_element_class = BitrixOnRails.define_iblock_class(@iblock.id)
    end

    should 'set multiple association for prop_values' do
      assert_not_nil @iblock_element_class.reflections[:prop_values]
    end

    should 'define access methods for iblock properties' do
      assert @iblock_element_class.instance_methods.include?(:synonym)
      assert @iblock_element_class.instance_methods.include?(:synonym=)
    end
  end

end
