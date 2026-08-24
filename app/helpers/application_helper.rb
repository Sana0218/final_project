# frozen_string_literal: true

module ApplicationHelper
  FLASH_CLASSES = {
    'notice' => 'bg-green-50 text-green-800 border border-green-200',
    'alert' => 'bg-red-50 text-red-800 border border-red-200',
    'warning' => 'bg-amber-50 text-amber-800 border border-amber-200'
  }.freeze

  def flash_class(type)
    FLASH_CLASSES.fetch(type.to_s, 'bg-gray-50 text-gray-800 border border-gray-200')
  end
end
