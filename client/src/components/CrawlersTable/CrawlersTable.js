import React, {Component, PropTypes} from 'react';
import {Table} from 'react-bootstrap';

export default class CrawlersTable extends Component {
  static propTypes = {
    crawlers: PropTypes.object
  };

  render() {
    const crawlers = (this.props.crawlers && this.props.crawlers.crawlers) || [];

    return (
      <div className="container">
        <h1>Crawlers</h1>

        <Table striped bordered condensed hover>
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th>Author</th>
              <th>Default URL</th>
            </tr>
          </thead>

          <tbody>
            {crawlers.map((crawler) => {
              return (
                <tr key={crawler.name}>
                  <td>{crawler.name}</td>
                  <td>{crawler.description}</td>
                  <td>{crawler.author.email}</td>
                  <td><a href={crawler.crawler.url}>{crawler.crawler.url}</a></td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
