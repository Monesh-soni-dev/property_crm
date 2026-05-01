class PagesController < ApplicationController
  before_action :set_page_title

  def about
    @page_title = "About Us"
  end

  def privacy
    @page_title = "Privacy Policy"
  end

  def terms
    @page_title = "Terms of Service"
  end

  def help
    @page_title = "Help Center"
  end

  def contact
    @page_title = "Contact Us"
  end

  def documentation
    @page_title = "Documentation"
  end

  private

  def set_page_title
    @page_section = "Information"
  end
end