import React, {Component, PropTypes} from 'react';
import {
  Button,
  Table
} from 'react-bootstrap';

export default class CrawlersTable extends Component {
  static propTypes = {
    crawlers: PropTypes.object,
    enqueueUrl: PropTypes.func,
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
              <th>Actions</th>
            </tr>
          </thead>

          <tbody>
            {crawlers.map((crawler) => {
              return (
                <tr key={crawler.name}>
                  <td>{crawler.name}</td>
                  <td>{crawler.description}</td>
                  <td>
                    <a href={`mailto:${crawler.author.email}?subject="Microcrawler"`}>{crawler.author.email}</a>
                  </td>
                  <td>
                    <a href={crawler.crawler.url} target="_blank" rel="noopener noreferrer">
                      {crawler.crawler.url}
                    </a>
                  </td>
                  <td>
                    <Button
                      bsStyle="primary"
                      bsSize="small"
                      type="button"
                      onClick={
                        () => {
                          this.props.enqueueUrl(crawler.crawler.url, crawler);
                        }
                      }
                    >Crawl</Button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
