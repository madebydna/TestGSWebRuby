# require 'spec_helper'
# require 'pdf-reader'
# require 'open-uri'
#
# # incomplete test
#
# io     = open('http://localhost:3000/gsr/pyoc.pdf?state=wi&id1=217')
# reader = PDF::Reader.new(io)
#
# describe 'PYOC' do
#
#     let(:font) {reader.pages[0]}
#     let(:text) {reader.pages[0].text}
#     it 'should have the font Helvetica' do
#       expect(font.fonts[:'F1.0'][:BaseFont]).to equal(:Helvetica)
#       expect(font.fonts[:'F2.0'][:BaseFont]).to equal(:"Helvetica-Bold")
#       expect(font.fonts[:'F3.0'][:BaseFont]).to equal(:"Helvetica-Oblique")
#     end
#
#     # string matching tests are all very brittle
#     it 'should have the correct school name' do
#       expect(text).to include('Fairview South')
#     end
#
#     it 'should have the correct school address' do
#       expect(text).to include('3525 Bermuda Blvd')
#       expect(text).to include('Brookfield, WI 53045')
#     end
#
#     it 'should have the correct phone number' do
#       expect(text).to include('Phone: (262) 781-9464')
#     end
#
#     it 'should have the correct grades, school type and district' do
#       expect(text).to include('2-12')
#       expect(text).to include('Public district')
#       expect(text).to include('Elmbrook School District')
#     end
#
#     this test is failing
#     it 'should have school size 21' do
#       expect(text).to equal(21)
#     end
#
#     it 'contains the correct number of pages' do
#       expect(reader.page_count).to equal(1)
#     end
#
# end
