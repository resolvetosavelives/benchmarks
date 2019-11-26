module GoalsHelper

  ##
  # takes an arg such as "jee1_ind_p12" and returns "P.1.2", or empty string
  def abbrev_from_named_id(key)
    return '' if key.blank?

    key.reverse.split('_').first.reverse.upcase.chars.join('.')
  end

end
