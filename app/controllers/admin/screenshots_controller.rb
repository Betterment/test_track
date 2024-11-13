# frozen_string_literal: true

class Admin::ScreenshotsController < ApplicationController
  def show
    split = Split.find(params[:split_id])
    variant_detail = split.variant_details.find_by!(variant: variant)
    raise ActiveRecord::RecordNotFound unless variant_detail.screenshot_file_name?

    redirect_to variant_detail.screenshot.expiring_url(300)
  end

  private

  def variant
    params.fetch(:id).split('.').first
  end
end
