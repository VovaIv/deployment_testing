require 'rails_helper'

describe 'Authentication', type: :system do
  let!(:admin_user) { User.create!(email: 'admin@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let!(:regular_user) { User.create!(email: 'user@test.com', password: 'password123', password_confirmation: 'password123', role: 'user') }
  let!(:survey) { Survey.create!(question: 'Test question?', answers_attributes: [{ text: 'Yes' }, { text: 'No' }]) }

  context 'when not signed in' do
    it 'redirects to sign in page' do
      visit surveys_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'when signed in as admin' do
    before do
      sign_in admin_user
    end

    it 'shows admin badge in header' do
      visit surveys_path
      expect(page).to have_content('Admin')
    end

    it 'shows edit and delete buttons' do
      visit surveys_path
      expect(page).to have_link('Edit')
      expect(page).to have_link('Delete')
    end

    it 'allows creating a survey' do
      visit new_survey_path
      fill_in 'survey[question]', with: 'Admin Question'
      fill_in 'survey[answers_attributes][0][text]', with: 'Option A'
      click_button 'Create Survey'
      expect(page).to have_content('Survey created successfully')
      expect(page).to have_content('Admin Question')
    end

    it 'allows editing a survey' do
      visit edit_survey_path(survey)
      fill_in 'survey[question]', with: 'Updated Question'
      click_button 'Update Survey'
      expect(page).to have_content('Survey updated successfully')
      expect(page).to have_content('Updated Question')
    end

    it 'allows deleting a survey without responses' do
      visit surveys_path
      expect {
        click_link 'Delete'
      }.to change { Survey.count }.by(-1)
    end
  end

  context 'when signed in as regular user' do
    before do
      sign_in regular_user
    end

    it 'does not show admin badge in header' do
      visit surveys_path
      expect(page).not_to have_content('Admin')
    end

    it 'does not show edit and delete buttons' do
      visit surveys_path
      expect(page).not_to have_link('Edit')
      expect(page).not_to have_link('Delete')
    end

    it 'cannot access edit page directly' do
      visit edit_survey_path(survey)
      expect(page).to have_current_path(surveys_path)
      expect(page).to have_content('You are not authorized to perform this action')
    end

    it 'allows responding to surveys' do
      visit surveys_path
      expect(page).to have_link('Respond')
    end
  end

  context 'sign in and sign out' do
    it 'allows user to sign in and sign out' do
      visit surveys_path
      expect(page).to have_current_path(new_user_session_path)
      
      fill_in 'Email', with: regular_user.email
      fill_in 'Password', with: 'password123'
      click_button 'Log in'
      
      expect(page).to have_current_path(surveys_path)
      expect(page).to have_content(regular_user.email)
      expect(page).to have_button('Sign Out')
      
      click_button 'Sign Out'
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
