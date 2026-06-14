ActiveAdmin.register Contact do
  menu label: 'Contact Messages', priority: 5

  actions :all, except: [:new, :edit]

  permit_params :status

  filter :first_name
  filter :last_name
  filter :email
  filter :inquiry_type, as: :select, collection: Contact::INQUIRY_TYPES
  filter :status, as: :select, collection: Contact::STATUSES
  filter :created_at

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone
    column :company
    column :inquiry_type
    column :status do |contact|
      status_tag contact.status, class: contact.status == 'new' ? 'orange' : 'green'
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row :email
      row :phone
      row :company
      row :inquiry_type
      row :message
      row :status do |contact|
        status_tag contact.status, class: contact.status == 'new' ? 'orange' : 'green'
      end
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  member_action :mark_read, method: :patch do
    resource.update(status: 'read')
    redirect_to admin_contact_path(resource), notice: 'Marked as read.'
  end

  action_item :mark_read, only: :show do
    link_to 'Mark as Read', mark_read_admin_contact_path(contact), method: :patch if contact.status == 'new'
  end
end
