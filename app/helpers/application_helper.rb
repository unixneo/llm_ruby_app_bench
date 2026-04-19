module ApplicationHelper
  def app_version
    Rails.root.join("VERSION").read.strip
  end
end
