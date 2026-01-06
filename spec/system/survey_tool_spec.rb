require 'rails_helper'

describe 'Survey Tool', type: :system do
  it 'allows to add a survey' do
    visit surveys_path

    click_link 'Create New Survey'

    fill_in 'survey[question]', with: 'Some question'
    click_button 'Create Survey'
    expect(page).to have_current_path(surveys_path)
    expect(page).to have_text('Some question')
    expect(page).to have_link('Respond')
    expect(page).to have_link('Delete')
  end

  it 'allows to answer the survey' do
    Survey.create(question: 'some question')
    visit surveys_path
    expect(page).to have_text('Total Responses: 0 Yes: 0% No: 0%', normalize_ws: true)
    click_link 'Respond'
    choose('Yes')
    click_button 'Create Survey response'
    expect(page).to have_text('Total Responses: 1 Yes: 100.0% No: 0.0%', normalize_ws: true)
  end
end
