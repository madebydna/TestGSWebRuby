import TestState from '../components/TestState';
import fetch from 'isomorphic-unfetch';
// import yamlEn from '../yaml/javascript.en.yml'
// import yamlEs from '../yaml/javascript.es.yml'
// import '../stylesheets/styles.scss'
// import '../stylesheets/styles2.scss'
import '../stylesheets/communities-next.scss'
// import '../../../../../../app/assets/stylesheets/community_post_load2.css.scss'


const Index = (props) => {
  const districts = props.data.districts
  const cities = props.data.cities
  // console.log(yamlEn)
  return <div>
    <p>Hello Next.js 2</p>
    <TestState
      districts={districts}
      locality={{nameLong: 'Andyville'}}
      cities={cities}
    />
  </div>
};

Index.getInitialProps = async function(stuff){
  const res = await fetch('http://localhost:3000/new-york/state_page_props');
  const data = await res.json();
  console.log(data);

  return {
    data
  };
}

export default Index;