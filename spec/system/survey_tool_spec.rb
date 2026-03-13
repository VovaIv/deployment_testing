require 'rails_helper'

describe 'Survey Tool', type: :system, js: true do
  let!(:admin_user) { User.create!(email: 'admin@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }

  before do
    sign_in admin_user
  end

  it 'allows to add a survey with answers' do
    visit surveys_path

    click_link 'Create New Survey'

    fill_in 'survey[question]', with: 'Some question'
    
    # Fill in the first answer field (already present)
    fill_in 'survey[answers_attributes][0][text]', with: 'Yes'
    
    # Add a second answer field
    click_button '+ Add Answer Option'
    
    # Fill in the second answer field
    within('[data-nested-form-target="target"]') do
      all('input[name*="[text]"]').last.set('No')
    end
    
    click_button 'Create Survey'
    expect(page).to have_current_path(surveys_path)
    expect(page).to have_text('Some question')
    expect(page).to have_link('Respond')
    expect(page).to have_link('Delete')
  end

  it 'allows to answer the survey' do
    Survey.create(question: 'some question', answers_attributes: [{ text: 'Yes' }, { text: 'No' }])
 
    visit surveys_path
    expect(page).to have_text('Total Responses:')
    expect(page).to have_text('Yes:')
    expect(page).to have_text('No:')
    expect(page).to have_text('0 (0%)', count: 2)  # Both Yes and No should show "0 (0%)"
    click_link 'Respond'
    choose('Yes')
    click_button 'Create Survey response'
    expect(page).to have_text('Total Responses:')
    expect(page).to have_text('1')  # Total responses: 1
    expect(page).to have_text('Yes:')
    expect(page).to have_text('1 (100.0%)')  # Yes: 1 (100.0%)
    expect(page).to have_text('No:')
    expect(page).to have_text('0 (0.0%)')    # No: 0 (0.0%)
  end
end
