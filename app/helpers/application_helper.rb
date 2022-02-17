module ApplicationHelper
  ##
  # HERE BE DRAGONS:
  #   On these javascript_pack_tag calls, there used to be use of the
  #   "async: true" attribute. It makes the pages load faster (according
  #   to Google Lighthouse tools) BUT there is a flash of unstyled
  #   content on those pages. We decided to go with slightly slower (~1s)
  #   to be more "correct".
  #
  # NB: please refer to the section in README.md ## A note on js packs and stylesheets
  def which_js
    is_homepage? ? "basic" : "application"
  end

  def is_homepage?
    controller_name.eql?("pages") && action_name.eql?("home")
  end
end
