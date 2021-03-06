# -*- coding: utf-8 -*-
class Iblock < ActiveRecord::Base
  self.table_name = :b_iblock

  # version - 1 или 2

  # iblock_type_id это строка, поэтом он срабатывает только если его указывать явано в foreign_key
  belongs_to :iblock_type, :foreign_key=>'iblock_type_id'

  # Они еще связаны между собой через iblock_section_element
  has_many :iblock_sections
  has_many :iblock_elements

  # has_many :iblock_section_elements, :through=>:iblock_sections

  # Список типов свойств по номерам которых создаются поля в
  # таблицах iblock_element_prop_sN
  has_many :iblock_properties

  has_many :iblock_fields
  has_many :iblock_groups

  class << self
    def s_props_class(id)
      # raise 'Только для инфоблоков 2-й версии' unless version==2
      "IblockElementPropS#{id}".constantize
    end

    def m_props_class(id)
      # raise 'Только для инфоблоков 2-й версии' unless version==2
      "IblockElementPropM#{id}".constantize
    end

    def all
      @cached_all ||= super
    end

    def get_properties(id)
      @properties = {} unless @properties
      @properties[id] ||= IblockProperty.where(:iblock_id => id).inject({}) { |a,e| a[e.id] = e; a }
    end

    def get_property(iblock_id, property_id)
      get_properties(iblock_id)[property_id]
    end

    def get_property_codes(id)
      @property_codes = {} unless @property_codes
      @property_codes[id] ||= get_properties(id).values.inject({}){ |a,e| a[e.code] = e.id; a }
    end

    # Определяем методы совпадающие с именами свойств и их установкой, например следующие записи идентичны:
    #
    #   post.iblock_element.property_set.name2 = 'имя'
    #   post.iblock_element.name2 = 'имя'
    #   post.name2 = 'имя'
    #   post.property_name2 = 'имя'
    #
    # Вызывается для классов наследуемых от IblockElement, типа Emitent и расширяемых
    # инфоблоком через has_infoblock, например Post
    #
    def define_delegated_methods(scope, id, is_class=false)
      # TODO Проверять не создали ли мы такие методы уже в рамках класса
      # это так если у класса установлен @iblock_id

      return if scope.is_a?(IblockElement) and scope.class.iblock_id

      eval_method = is_class ? :class_eval : :instance_eval

      get_property_codes(id).each { |code, number|

        if scope.respond_to? code
          logger.warn "Iblock(#{id}): Метод #{code} уже определен в #{scope.class}"
        else
          scope.send eval_method, "def #{code}; property_set.send('#{code}'); end"
        end
        scope.send eval_method,  "def property_#{code}; property_set.send('#{code}'); end"


        # TODO Сделать .to_i если тип свойства NUMERIC, также для boolean
        if scope.respond_to? "#{code}="
          logger.warn "Iblock(#{id}): Метод #{code}= уже определен в #{scope.class}"
        else
          scope.send eval_method, "def #{code}=(value); property_set.send('#{code}=', value); end"
        end
        scope.send eval_method, "def property_#{code}=(value); property_set.send('#{code}=', value); end"
      }

    end
  end # self

  def to_s
    name
  end

  def get_property(property_id)
    self.class.get_property(id, property_id)
  end

  def property_codes
    self.class.get_property_codes(id)
  end
end
