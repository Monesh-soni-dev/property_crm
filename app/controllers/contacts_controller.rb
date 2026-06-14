class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to contact_path, notice: "Thank you! Your message has been sent. We'll get back to you soon."
    else
      @page_title = "Contact Us"
      render 'pages/contact', status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone, :company, :inquiry_type, :message)
  end
end
