class Customer < ApplicationRecord
    ## Associations ##
    has_many :orders, dependent: :destroy

    ## Validations ##
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :phone, presence: true, uniqueness: true
end
