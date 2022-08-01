# frozen_string_literal: true

##
# This class is used to validate LA request data filled in +app/views/la_request/la_request_form.html.haml+.
class LaRequestForm
  # allow using ActiveRecord validation
  include ActiveModel::Validations
  # Email address regular expression.
  EMAIL_FORMAT = %r{\A(([\w\d!#$%&'*+\-/=?^_`{|}~]+)(\.{1}))*
    ([\w\d!#$%&'*+\-/=?^_`{|}~]+)@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\z}x

  attr_accessor :name, :email, :details

  validates :name, presence: { message: I18n.t('la_request_form.errors.name_required'), link: '#name-error' }
  validates :email, presence: { message: I18n.t('email.errors.required'), link: '#email-error' }
  validates :email, format: {
    with: EMAIL_FORMAT, message: I18n.t('email.errors.invalid_format'), link: '#email-error'
  }, allow_blank: true
  validates :details, presence: { message: I18n.t('la_request_form.errors.details_required'), link: '#details-error' }

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +la_params+ - params, name, email and details
  def initialize(la_params)
    @name = la_params[:name]
    @email = la_params[:email]
    @details = la_params[:details]
  end
end
