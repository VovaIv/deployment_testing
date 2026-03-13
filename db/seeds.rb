# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'admin'
end

# Create regular user
User.find_or_create_by!(email: 'user@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'user'
end

['First Question. You agree or not', 'Second Question. You agree or not',
 'Third Question. You agree or not', 'Fourth Question. You agree or not',
 'Fifth Question. You agree or not', 'Last Question. You agree or not'].each do |question|
  Survey.find_or_create_by!(question: question) do |survey|
    survey.answers.build(text: 'Yes')
    survey.answers.build(text: 'No')
  end
end
