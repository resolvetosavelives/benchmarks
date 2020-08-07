module ApplicationHelper
  ##
  # HERE BE DRAGONS:
  #   On these javascript_pack_tag calls, there used to be use of the
  #   "async: true" attribute. It makes the pages load faster (according
  #   to Google Lighthouse tools) BUT there is a flash of unstyled
  #   content on those pages. We decided to go with slightly slower (~1s)
  #   to be more "correct".
  def which_js
    if is_homepage?
      javascript_pack_tag 'basic', "data-turbolinks-track": "reload"
    else
      javascript_pack_tag 'application', "data-turbolinks-track": "reload"
    end
  end

  def which_footer
    if is_homepage?
      render "layouts/home_page_footer"
    else
      render "layouts/standard_footer"
    end
  end

  def is_homepage?
    controller_name.eql?("pages") && action_name.eql?("home")
  end
end
