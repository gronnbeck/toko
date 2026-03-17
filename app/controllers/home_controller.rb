# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    tasks = Task.order(created_at: :desc)
    render ::Views::Home::Index.new(tasks:)
  end
end
