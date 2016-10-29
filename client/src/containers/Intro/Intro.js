import React, {Component} from 'react';
import { Link } from 'react-router';

export default class Intro extends Component {
  render() {
    return (
      <div className="container">
        <div className="jumbotron" style={{marginTop: '50px'}} >
          <div className="container">
            <h1>Microcrawler</h1>

            <p>&lt;Add Some Bullshit Here&gt;</p>

            <p>
              <Link to="/" className="btn btn-primary btn-lg" role="button" style={{marginRight: '5px'}}>
                Login or Sign-up &raquo;
              </Link>

              <Link to="/" className="btn btn-default btn-lg" role="button">
                Gallery &raquo;
              </Link>
            </p>
          </div>
        </div>

        <div className="row">
          <div className="col-md-4">
            <h2>Easy To Use</h2>

            <p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dictum ligula at elit pulvinar,
              non aliquet lacus venenatis. Maecenas in faucibus leo. Nullam maximus nisi non auctor porttitor.
              Sed risus nisi, eleifend id bibendum venenatis, maximus ac dolor. Sed sed elit nulla.
              Mauris sapien nulla, mattis ut nulla eget, consequat aliquet felis. Duis non elit placerat,
              elementum erat et, venenatis mi. Cras lobortis nibh nisi, pretium maximus lorem rhoncus non.
              Aliquam erat volutpat. Nulla auctor ultricies dolor at convallis.
              Aliquam sed tortor a felis tincidunt imperdiet.
              Curabitur sapien leo, euismod quis nisl et, accumsan molestie lectus.
            </p>

            <p>
              <Link to="/" className="btn btn-default" role="button">
                More &raquo;
              </Link>
            </p>
          </div>

          <div className="col-md-4">
            <h2>Cloud Based</h2>

            <p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dictum ligula at elit pulvinar,
              non aliquet lacus venenatis. Maecenas in faucibus leo. Nullam maximus nisi non auctor porttitor.
              Sed risus nisi, eleifend id bibendum venenatis, maximus ac dolor. Sed sed elit nulla.
              Mauris sapien nulla, mattis ut nulla eget, consequat aliquet felis. Duis non elit placerat,
              elementum erat et, venenatis mi. Cras lobortis nibh nisi, pretium maximus lorem rhoncus non.
              Aliquam erat volutpat. Nulla auctor ultricies dolor at convallis.
              Aliquam sed tortor a felis tincidunt imperdiet.
              Curabitur sapien leo, euismod quis nisl et, accumsan molestie lectus.
            </p>

            <p>
              <Link to="/" className="btn btn-default" role="button">
                More &raquo;
              </Link>
            </p>
          </div>

          <div className="col-md-4">
            <h2>Distributed</h2>

            <p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dictum ligula at elit pulvinar,
              non aliquet lacus venenatis. Maecenas in faucibus leo. Nullam maximus nisi non auctor porttitor.
              Sed risus nisi, eleifend id bibendum venenatis, maximus ac dolor. Sed sed elit nulla.
              Mauris sapien nulla, mattis ut nulla eget, consequat aliquet felis. Duis non elit placerat,
              elementum erat et, venenatis mi. Cras lobortis nibh nisi, pretium maximus lorem rhoncus non.
              Aliquam erat volutpat. Nulla auctor ultricies dolor at convallis.
              Aliquam sed tortor a felis tincidunt imperdiet.
              Curabitur sapien leo, euismod quis nisl et, accumsan molestie lectus.
            </p>

            <p>
              <Link to="/" className="btn btn-default" role="button">
                More &raquo;
              </Link>
            </p>
          </div>
        </div>
      </div>
    );
  }
}
