# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

['First Question. You agree or not', 'Second Question. You agree or not',
 'Third Question. You agree or not', 'Fourth Question. You agree or not',
 'Fifth Question. You agree or not', 'Last Question. You agree or not'].each do |question|
  Survey.create(question: question)
end
