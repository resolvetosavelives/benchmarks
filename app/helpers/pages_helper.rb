module PagesHelper
  def technical_area_to_id(technical_areas, technical_area_name)
    technical_areas.detect { |ta| ta.text.eql?(technical_area_name) }&.id
  end
end
