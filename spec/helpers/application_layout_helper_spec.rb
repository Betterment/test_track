require 'rails_helper'

RSpec.describe ApplicationLayoutHelper, type: :helper do
  describe '#page_title' do
    it 'defaults to Test Track Admin' do
      expect(helper.page_title).to eq 'Test Track Admin'
    end

    it 'accepts a page title' do
      helper.content_for :page_title, 'foo'
      expect(helper.page_title).to eq 'foo'
    end
  end

  describe '#header_modifier' do
    context 'when the header_modifier content_for has been provided' do
      before do
        helper.content_for :header_modifier, 'green'
      end

      it 'returns the custom modifier' do
        expect(helper.header_modifier).to eq 'green'
      end
    end
  end

  describe '#site_layout_body_color' do
    it 'defaults to near white' do
      expect(helper.site_layout_body_color).to eq 'nearWhite'
    end

    it 'accepts a custom color' do
      helper.content_for :site_layout_body_color, 'white'
      expect(helper.site_layout_body_color).to eq 'white'
    end
  end

  describe '#site_layout_wrapper_classes' do
    it 'returns descendant class and color modifier class' do
      expect(helper.site_layout_wrapper_classes).to eq 'sc-SiteLayout sc-SiteLayout--nearWhite'
    end

    it 'returns descendant class and color modifier class' do
      helper.content_for :site_layout_body_color, 'blue'
      expect(helper.site_layout_wrapper_classes).to eq 'sc-SiteLayout sc-SiteLayout--blue'
    end
  end

  describe '#controller_css_class' do
    it 'creates a controller css class' do
      allow(helper).to receive(:controller_path).and_return 'admin/splits'
      expect(helper.controller_css_class).to eq('AdminSplits')
    end
  end

  describe '#controller_action_css_class' do
    it 'creates a controller action css class' do
      allow(helper).to receive(:controller_path).and_return 'admin/splits/edit'
      allow(helper).to receive(:action_name).and_return 'edit'
      expect(helper.controller_action_css_class).to eq('AdminSplitsEdit--edit')
    end
  end
end
