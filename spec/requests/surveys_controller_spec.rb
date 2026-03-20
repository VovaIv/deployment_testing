require 'rails_helper'

RSpec.describe SurveysController, type: :request do
  let(:admin) do
    User.create!(email: 'admin@example.com', password: 'password123',
                 password_confirmation: 'password123', role: 'admin')
  end
  let(:non_admin) do
    User.create!(email: 'user@example.com', password: 'password123',
                 password_confirmation: 'password123', role: 'user')
  end

  describe 'GET /surveys/new' do
    context 'when unauthenticated' do
      it 'redirects to the sign-in page' do
        get new_survey_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as a non-admin' do
      before { sign_in non_admin }

      it 'redirects away with an alert' do
        get new_survey_path
        expect(response).to redirect_to(surveys_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'returns 200' do
        get new_survey_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /surveys' do
    context 'when unauthenticated' do
      it 'redirects to the sign-in page' do
        post surveys_path, params: { survey: { question: 'Q?', answers_attributes: { '0' => { text: 'Yes' } } } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as a non-admin' do
      before { sign_in non_admin }

      it 'redirects away and does not create a survey' do
        expect do
          post surveys_path, params: { survey: { question: 'Q?', answers_attributes: { '0' => { text: 'Yes' } } } }
        end.not_to change(Survey, :count)
        expect(response).to redirect_to(surveys_path)
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'creates a survey and redirects' do
        expect do
          post surveys_path, params: { survey: { question: 'Q?', answers_attributes: { '0' => { text: 'Yes' } } } }
        end.to change(Survey, :count).by(1)
        expect(response).to redirect_to(surveys_path)
      end
    end
  end
end
