require 'spec_helper'

describe 'request paths with periods' do
  it 'should re-direct to path without period' do
    get 'http://www.greatschools.org/wisconsin/st.-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/'
    expect(response).to redirect_to(
      'http://www.greatschools.org/wisconsin/st-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/')
  end

  it 'should remove two periods.' do
    get 'http://www.greatschools.org/wisconsin/st.-francis/preschools/Messiah-Evangelical.-Luth-Ps/4868/'
    expect(response).to redirect_to(
      'http://www.greatschools.org/wisconsin/st-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/')
  end

  it 'should re-direct to path without period for pk subdomain' do
    get 'http://pk.greatschools.org/wisconsin/st.-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/'
    expect(response).to redirect_to(
      'http://pk.greatschools.org/wisconsin/st-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/')
  end

  it 'should remove two periods. for pk subdomain' do
    get 'http://pk.greatschools.org/wisconsin/st.-francis/preschools/Messiah-Evangelical.-Luth-Ps/4868/'
    expect(response).to redirect_to(
      'http://pk.greatschools.org/wisconsin/st-francis/preschools/Messiah-Evangelical-Luth-Ps/4868/')
  end

end