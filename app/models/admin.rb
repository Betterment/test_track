class Admin < ActiveRecord::Base
  has_many :bulk_assignments, dependent: :nullify

  class << self
    def from_saml(auth)
      lookup_admin(email: auth["uid"].downcase, full_name: auth["info"]["name"], provider: "SAML")
    end

    private

    def lookup_admin(opts)
      admin = admin_by_email(opts.delete(:email))

      admin&.update!(opts)

      admin
    end

    def admin_by_email(email)
      find_or_initialize_by(email:)
    end

    def devise_args
      %i(trackable lockable timeoutable).tap do |a|
        if ENV['SAML_ISSUER'].present?
          a.push(:omniauthable, { omniauth_providers: [:saml] })
        else
          a.push(:database_authenticatable)
        end
      end
    end
  end

  devise(*devise_args)
end
