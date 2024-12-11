module ApplicationHelper
  def human_readable_size(bytes)
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    size = bytes.to_f
    unit = units.shift

    while size >= 1024 && units.any?
      size /= 1024
      unit = units.shift
    end

    "#{size.round(2)} #{unit}"
  end

  def class_for_flash(type)
    case type
    when 'alert'
      'alert-warning'
    else
      'alert-success'
    end
  end
end
