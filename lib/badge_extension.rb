# plugins/my-badge-plugin/lib/badge_extension.rb
module BadgeExtension
  def badges
    user_badges.map do |user_badge|
      {
        id: user_badge.badge.id,
        name: user_badge.badge.name,
        description: user_badge.badge.description,
        icon: user_badge.badge.icon
      }
    end
  end
end

# โหลด Extension ใน Model User
after_initialize do
  User.class_eval do
    include BadgeExtension
  end
end