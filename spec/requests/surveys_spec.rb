require 'rails_helper'

RSpec.describe 'Surveys', type: :request do
  let!(:admin_user) do
    User.create!(email: 'admin@test.com', password: 'password123',
                 password_confirmation: 'password123', role: 'admin')
  end
  let!(:regular_user) do
    User.create!(email: 'user@test.com', password: 'password123',
                 password_confirmation: 'password123', role: 'user')
  end

  describe 'GET /surveys/new' do
    context 'when signed in as regular user' do
      before { sign_in regular_user }

      it 'redirects to surveys path with unauthorized alert' do
        get new_survey_path
        expect(response).to redirect_to(surveys_path)
      end
    end

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'allows access' do
        get new_survey_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /surveys' do
    context 'when signed in as regular user' do
      before { sign_in regular_user }

      it 'redirects to surveys path with unauthorized alert' do
        post surveys_path, params: { survey: { question: 'Test question?' } }
        expect(response).to redirect_to(surveys_path)
      end
    end

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'creates the survey' do
        expect {
          post surveys_path, params: { survey: { question: 'Test question?', answers_attributes: [{ text: 'Yes' }, { text: 'No' }] } }
        }.to change(Survey, :count).by(1)
        expect(response).to redirect_to(surveys_path)
      end
    end
  end
end
