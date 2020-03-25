# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchVrnForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:params) do
    {
      vrn: vrn,
      historic: historic,
      start_date_day: start_date_day,
      start_date_month: start_date_month,
      start_date_year: start_date_year,
      end_date_day: end_date_day,
      end_date_month: end_date_month,
      end_date_year: end_date_year
    }
  end

  let(:vrn) { 'CU57ABC' }
  let(:historic) { 'false' }
  let(:start_date_day) { '10' }
  let(:start_date_month) { '3' }
  let(:start_date_year) { '2020' }
  let(:end_date_day) { '14' }
  let(:end_date_month) { '3' }
  let(:end_date_year) { '2020' }

  before { form.valid? }

  context 'with proper VRN' do
    it { is_expected.to be_valid }
  end

  context 'VRN validation' do
    context 'when VRN is empty' do
      let(:vrn) { '' }

      it { is_expected.not_to be_valid }

      it_behaves_like 'an invalid attribute input', :vrn, I18n.t('search_vrn_form.vrn_missing')
    end

    context 'when VRN is too long' do
      let(:vrn) { 'ABCDE' * 4 }

      it { is_expected.not_to be_valid }

      it_behaves_like 'an invalid attribute input', :vrn, I18n.t('search_vrn_form.vrn_too_long')
    end

    context 'when VRN has special signs' do
      let(:vrn) { 'ABCDE$%' }

      it_behaves_like 'an invalid attribute input', :vrn, I18n.t('search_vrn_form.invalid_format')
    end
  end

  describe 'historical search' do
    let(:historic) { 'true' }

    context 'with proper VRN and dates' do
      it { is_expected.to be_valid }
    end

    context 'dates should be in ISO 8601 format' do
      it 'returns a proper `start_date` format' do
        expect(form.start_date).to eq('2020-03-10')
      end

      it 'returns a proper `end_date` format' do
        expect(form.end_date).to eq('2020-03-14')
      end
    end

    context 'with invalid start dates' do
      context 'when day is missing' do
        let(:start_date_day) { '' }

        it_behaves_like 'an invalid attribute input', :start_date, 'Start date must include a day'
      end

      context 'when month is missing' do
        let(:start_date_month) { '' }

        it_behaves_like 'an invalid attribute input',
                        :start_date,
                        'Start date must include a month'
      end

      context 'when year is missing' do
        let(:start_date_year) { '' }

        it_behaves_like 'an invalid attribute input', :start_date, 'Start date must include a year'
      end

      context 'when day and month are missing' do
        let(:start_date_day) { '' }
        let(:start_date_month) { '' }

        it_behaves_like 'an invalid attribute input',
                        :start_date,
                        'Start date must include a day and month'
      end

      context 'when day and year are missing' do
        let(:start_date_day) { '' }
        let(:start_date_year) { '' }

        it_behaves_like 'an invalid attribute input',
                        :start_date,
                        'Start date must include a day and year'
      end

      context 'when month and year are missing' do
        let(:start_date_month) { '' }
        let(:start_date_year) { '' }

        it_behaves_like 'an invalid attribute input',
                        :start_date,
                        'Start date must include a month and year'
      end

      context 'when year is in an invalid format' do
        let(:start_date_year) { '-2020' }

        it_behaves_like 'an invalid attribute input',
                        :start_date,
                        'Enter a real start date'
      end

      context 'when the start date not earlier than end date' do
        context 'show errors' do
          let(:start_date_day) { Date.tomorrow.day.to_s }
          let(:start_date_month) { Date.tomorrow.month.to_s }
          let(:start_date_year) { Date.tomorrow.year.to_s }
          let(:end_date_day) { Date.current.day.to_s }
          let(:end_date_month) { Date.current.month.to_s }
          let(:end_date_year) { Date.current.year.to_s }

          it_behaves_like 'an invalid attribute input',
                          :start_date,
                          'Start date must be earlier than end date'
        end
      end
    end

    context 'with invalid end dates' do
      context 'when day is missing' do
        let(:end_date_day) { '' }

        it_behaves_like 'an invalid attribute input', :end_date, 'End date must include a day'
      end

      context 'when month is missing' do
        let(:end_date_month) { '' }

        it_behaves_like 'an invalid attribute input', :end_date, 'End date must include a month'
      end

      context 'when year is missing' do
        let(:end_date_year) { '' }

        it_behaves_like 'an invalid attribute input', :end_date, 'End date must include a year'
      end

      context 'when day and month are missing' do
        let(:end_date_day) { '' }
        let(:end_date_month) { '' }

        it_behaves_like 'an invalid attribute input',
                        :end_date,
                        'End date must include a day and month'
      end

      context 'when day and year are missing' do
        let(:end_date_day) { '' }
        let(:end_date_year) { '' }

        it_behaves_like 'an invalid attribute input',
                        :end_date,
                        'End date must include a day and year'
      end

      context 'when month and year are missing' do
        let(:end_date_month) { '' }
        let(:end_date_year) { '' }

        it_behaves_like 'an invalid attribute input',
                        :end_date,
                        'End date must include a month and year'
      end

      context 'when year is in an invalid format' do
        let(:end_date_year) { '-2020' }

        it_behaves_like 'an invalid attribute input',
                        :end_date,
                        'Enter a real end date'
      end
    end
  end
end