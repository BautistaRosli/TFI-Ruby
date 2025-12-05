class Client < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "debe tener un formato válido (ej. ejemplo@dominio.com)" }
  validates :document_number, presence: true, uniqueness: { scope: :document_type }
  validates :document_type, presence: true, inclusion: { in: %w[DNI LC LE PASAPORTE] }
end
