# frozen_string_literal: true

class Agent < ApplicationRecord
  enum :status, { online: 0, busy: 1, missing: 2, offline: 3 }

  belongs_to :organization, optional: true
  has_one :mission, -> { where(kind: :mission) }, class_name: "Prompt", as: :promptable, dependent: :destroy
  has_many :agent_skills, dependent: :destroy
  has_many :skills, through: :agent_skills
  has_many :task_relevances, dependent: :destroy

  validates :name, presence: true

  before_create :assign_token

  def mission_digest
    body = mission&.body
    return nil unless body

    Digest::SHA256.hexdigest(body)
  end

  def display_status
    return :offline if last_seen_at.nil? || last_seen_at < 10.minutes.ago
    return :missing if last_seen_at < 5.minutes.ago
    status.to_sym
  end

  def ping!(status:)
    update!(last_seen_at: Time.current, status:)
  end

  private

  def assign_token
    self.token ||= SecureRandom.uuid
  end
end
