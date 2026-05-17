namespace :dummy do
  desc "Create 100 dummy properties and 100 dummy leads for testing"
  task seed: :environment do
    require "faker" rescue nil  # optional, works without it

    # ── helpers ─────────────────────────────────────────────────────────────
    PROPERTY_TYPES   = %w[apartment villa plot commercial penthouse studio].freeze
    STATUSES         = %w[available available available booked blocked registered].freeze
    FACINGS          = %w[North South East West North-East North-West South-East South-West].freeze
    FURNISHING       = %w[furnished semi_furnished unfurnished].freeze
    PARKING          = %w[available not_available covered open].freeze
    POSSESSION       = %w[ready_to_move under_construction immediate_possession].freeze
    WATER            = %w[municipal borewell both].freeze
    POWER            = %w[available not_available].freeze
    TRANSACTION      = %w[new_booking resale].freeze
    OWNERSHIP        = %w[freehold leasehold].freeze
    FLOORING         = %w[vitrified marble wooden tiles].freeze
    BOUNDARY         = %w[compound individual].freeze
    LEAD_SOURCES     = %w[website referral social_media walk_in phone_call].freeze
    LEAD_STAGES      = %w[new_lead contacted interested visit_scheduled negotiation closed].freeze
    CITIES           = ["Mumbai", "Pune", "Bangalore", "Hyderabad", "Chennai",
                        "Delhi", "Noida", "Gurgaon", "Ahmedabad", "Kolkata"].freeze
    STATES           = ["Maharashtra", "Karnataka", "Telangana", "Tamil Nadu",
                        "Delhi", "Uttar Pradesh", "Haryana", "Gujarat", "West Bengal"].freeze
    NAMES            = ["Aarav", "Arjun", "Riya", "Priya", "Neha", "Karan", "Rohit",
                        "Sneha", "Meera", "Vivek", "Anil", "Suman", "Pooja", "Nikhil",
                        "Divya", "Rahul", "Anjali", "Suresh", "Lakshmi", "Gaurav"].freeze
    SURNAMES         = ["Sharma", "Patel", "Verma", "Singh", "Kumar", "Joshi", "Mehta",
                        "Shah", "Nair", "Reddy", "Das", "Mishra", "Pandey", "Gupta"].freeze

    def rand_name
      "#{NAMES.sample} #{SURNAMES.sample}"
    end

    def rand_email(name)
      "#{name.downcase.gsub(' ', '.')}.#{rand(1000)}@example.com"
    end

    # ── find builder & projects ──────────────────────────────────────────────
    builder = User.where(role: "builder").first
    abort "❌  No builder found. Create a builder user first." unless builder

    projects = Project.where(user_id: builder.id)
    if projects.empty?
      puts "⚠️  No projects found for builder. Creating one..."
      projects = [Project.create!(
        name: "Sunrise Residency",
        location: "Pune",
        description: "Premium residential project",
        status: "active",
        total_units: 200,
        start_date: 1.year.ago,
        end_date: 2.years.from_now,
        user: builder
      )]
    end

    agent = User.where(role: "agent").first
    abort "❌  No agent found. Create an agent user first." unless agent

    # ── create 100 properties ────────────────────────────────────────────────
    puts "\n🏠  Creating 100 dummy properties..."
    created_props = 0

    100.times do |i|
      project = projects.sample
      city    = CITIES.sample
      idx     = i + 1
      type    = PROPERTY_TYPES.sample
      beds    = type == "plot" ? 0 : rand(1..5)
      baths   = type == "plot" ? 0 : [beds - 1, 1].max + rand(0..1)
      area    = (200 + rand(2800)).to_f
      price   = case type
                when "plot"       then (area * rand(800..2000))
                when "commercial" then (area * rand(5000..15000))
                else                   (area * rand(3000..12000))
                end.round(-3)  # round to nearest thousand

      Property.create!(
        project:           project,
        user:              builder,
        title:             "#{beds > 0 ? "#{beds}BHK " : ''}#{type.capitalize} in #{city} ##{idx}",
        unit_number:       "#{('A'..'H').to_a.sample}#{100 + rand(200)}",
        floor:             rand(0..30),
        property_type:     type,
        price:             price,
        area:              area,
        bedrooms:          beds,
        bathrooms:         baths,
        facing:            FACINGS.sample,
        status:            STATUSES.sample,
        city:              city,
        state:             STATES.sample,
        pincode:           "4#{rand(10000..99999)}",
        address:           "Plot #{rand(1..200)}, Sector #{rand(1..50)}, #{city}",
        description:       "Well-designed #{type} with modern amenities. #{["Vastu compliant.", "Corner unit.", "Park facing.", "Main road access.", "Gated society."].sample}",
        features:          ["24/7 Security", "Gym", "Swimming Pool", "Club House", "Children's Play Area", "Power Backup", "Parking"].sample(rand(2..5)).join(", "),
        age_of_property:   rand(0..15),
        possession_status: POSSESSION.sample,
        parking:           PARKING.sample,
        furnishing_status: FURNISHING.sample,
        water_supply:      WATER.sample,
        power_backup:      POWER.sample,
        transaction_type:  TRANSACTION.sample,
        ownership_type:    OWNERSHIP.sample,
        boundary_wall:     BOUNDARY.sample,
        flooring_type:     FLOORING.sample,
        road_width:        "#{rand(20..60)} ft",
        location_advantage: "Close to #{["metro station", "hospital", "school", "IT park", "shopping mall"].sample(2).join(' and ')}.",
        contact_person:    rand_name,
        contact_phone:     "9#{rand(100_000_000..999_999_999)}",
        contact_email:     "sales#{idx}@example.com"
      )
      created_props += 1
      print "." if (i + 1) % 10 == 0
    end

    puts "\n✅  Created #{created_props} properties."

    # ── create 100 leads ─────────────────────────────────────────────────────
    puts "\n📋  Creating 100 dummy leads..."
    all_properties = Property.all.to_a
    created_leads  = 0
    skipped_leads  = 0

    # use both builder and agent as lead owners so we get variety
    lead_owners = [builder, agent].compact

    # Shuffle properties and assign one lead per property to avoid uniqueness conflicts
    all_properties.shuffle.first(100).each_with_index do |property, i|
      user = lead_owners[i % lead_owners.size]

      # skip if this (user, property) pair already exists
      next if Lead.exists?(user_id: user.id, property_id: property.id)

      name = rand_name
      Lead.create!(
        user:              user,
        project:           property.project,
        property:          property,
        customer_name:     name,
        customer_email:    rand_email(name),
        customer_phone:    "9#{rand(100_000_000..999_999_999)}",
        source:            LEAD_SOURCES.sample,
        budget:            (property.price * rand(0.8..1.2)).round(-4),
        stage:             LEAD_STAGES.sample,
        notes:             ["Interested in site visit.", "Called twice, no response.", "Wants negotiation on price.", "Ready to book this week.", "Sent brochure on WhatsApp."].sample,
        property_name:     property.title,
        property_location: property.city,
        property_type:     property.property_type,
        follow_up_date:    Date.today + rand(1..30)
      )
      created_leads += 1
      print "." if (created_leads) % 10 == 0
    rescue ActiveRecord::RecordInvalid => e
      skipped_leads += 1
    end

    puts "\n✅  Created #{created_leads} leads. Skipped #{skipped_leads} duplicates."
    puts "\n🎉  Done! Summary:"
    puts "   Properties : #{Property.count}"
    puts "   Leads      : #{Lead.count}"
    puts "   Builder    : #{builder.email}"
    puts "   Agent      : #{agent.email}"
  end

  desc "Remove all dummy data created by dummy:seed (properties with example.com contacts + their leads)"
  task cleanup: :environment do
    leads_deleted = Lead.joins(:property)
                        .where(properties: { contact_email: /example\.com/ })
                        .delete_all
    props_deleted = Property.where("contact_email LIKE ?", "%example.com%").delete_all
    puts "🗑️  Removed #{props_deleted} dummy properties and #{leads_deleted} leads."
  end
end
