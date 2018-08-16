import React from "react";
import PropTypes from "prop-types";
import Button from "react_components/button";

const TopSchools = ({schools}) => {
	// const schoolElements = (schools) => (schools.map(school => (
	// 	<tr>

	// 	</tr>
	// )))
	return (
		<div className="top-school-module">
			<h3>Top schools by</h3>
			<p>
			The GreatSchools Rating provides an overall snapshot of school
			quality based on how well a school prepares all its students for
			postsecondary success-be it college or career. Learn More
			</p>
			{/* Button Rows */}
			<span className="button-group">
				<Button label={"Elementary"} />
				<Button label={"Middle"} />
				<Button label={"High"} />
			</span>
			{/* School List */}
			<section className='school-table'>
				<table>
					<thead>
						<tr>
							<th className='school'>School</th>
							<th>Student</th>
							<th>Reviews</th>
							<th>District</th>
						</tr>
					</thead>
					<tbody>
						{/* {schoolElements} */}
					</tbody>
				</table>
			</section>
		</div>
	)
}

export default TopSchools;