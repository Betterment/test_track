class Admin < ActiveRecord::Base
  has_many :bulk_assignments

  class << self
    def from_saml(auth)
      lookup_admin(email: auth["uid"].downcase, full_name: auth["info"]["name"], provider: "SAML")
    end

    private

    def lookup_admin(opts)
      admin = admin_by_email(opts.delete(:email))

      admin.update_attributes!(opts) if admin

      admin
    end

    def admin_by_email(email)
      find_or_initialize_by(email: email)
    end

    def devise_args
      [:trackable, :lockable, :timeoutable].tap do |a|
        if ENV['SAML_ISSUER'].present?
          a.concat [:omniauthable, { omniauth_providers: [:saml] }]
        else
          a.concat [:database_authenticatable]
        end
      end
    end
  end

  devise(*devise_args)
end
