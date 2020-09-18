import React, { useState, useCallback } from "react";
import PropTypes from "prop-types";
import CarouselDisplay from "react_components/home/carousel_display";
import Card from "react_components/home/card";
import ArrowLeft from "react_components/icons/arrow_left";
import ArrowRight from "react_components/icons/arrow_right";
import { XS } from "util/viewport";
import { t } from "util/i18n";
import slideshow1 from "home/slideshows_2/01_CSA_Insights_2020_Success_without_Selection.jpg";
import slideshow2 from "home/slideshows_2/02_Parent_Insights_Supporting_learning_at_home_during_COVID-19.png";
import slideshow3 from "home/slideshows_2/03_GreatSchools_Transparency_Report_Web.jpg";
import slideshow4 from "home/slideshows_2/04_GreatSchools_College_Sucess_Awards_Report_Final-1.jpg";
import slideshow5 from "home/slideshows_2/05_searching_for_opportunity.jpg";

const slideshowUrls = [
  slideshow1,
  slideshow2,
  slideshow3,
  slideshow4,
  slideshow5,
];

const Carousel = ({ size }) => {
  const [index, setIndex] = useState(0);
  const [direction, setDirection] = useState("right");

  const translateRight = useCallback(() => {
    setDirection("right");
    setIndex((index + 1 + slideshowUrls.length) % slideshowUrls.length);
  });

  const translateLeft = useCallback(() => {
    setDirection("left");
    setIndex((index - 1 + slideshowUrls.length) % slideshowUrls.length);
  });

  const buttons = (hw) => {
    return (
      <div className="carousel-buttons">
        <ArrowLeft
          onClick={translateLeft}
          className={"arrow"}
          height={hw}
          width={hw}
        />
        <ArrowRight
          onClick={translateRight}
          className={"arrow"}
          height={hw}
          width={hw}
        />
      </div>
    );
  }

  return (
    <React.Fragment>
      <h2>{t('show.Research')}</h2>
      <p style={{textAlign: 'center', paddingBottom: '3em'}}>{t("show.Research-subtext")}</p>
      <div className="module-row">
        <Card
          index={index}
          slideshowUrls={slideshowUrls}
          direction={direction}
          size={size}
        />
        <div className="carousel-row">
          <div className="carousel-container">
            <CarouselDisplay
              type="large"
              size={size}
              index={index}
              direction={direction}
              slideshowUrls={slideshowUrls}
              callback={translateRight}
            />
            <div>
              <div style={{ display: "flex" }}>
                <CarouselDisplay
                  type="small-left"
                  size={size}
                  index={
                    (index + 1 + slideshowUrls.length) % slideshowUrls.length
                  }
                  direction={direction}
                  slideshowUrls={slideshowUrls}
                />
                {size > XS && (
                  <CarouselDisplay
                    type="small-right"
                    size={size}
                    index={
                      (index + 2 + slideshowUrls.length) % slideshowUrls.length
                    }
                    direction={direction}
                    slideshowUrls={slideshowUrls}
                  />
                )}
              </div>
              {size == XS ? buttons("20") : buttons()}
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  );
};

Carousel.propTypes = {
  size: PropTypes.number,
};

Carousel.defaultProps = {
  size: 2
};


export default props => <Carousel {...props}/>;