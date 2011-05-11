#ifndef TEXT_CLEANER_INCLUDE_GUARD
#define TEXT_CLEANER_INCLUDE_GUARD

#include <string>
#include <istream>
#include <boost/unordered_map.hpp>
#include <tbb/concurrent_queue.h>
#include <boost/cstdint.hpp>
typedef boost::uint32_t uint32_t;

#include "pipes/pipe.hpp"

#include "cutout_t.hpp"

namespace trtok {

/* The TextCleaner class will be responsible for decoding the input text,
 * stripping off the XML markup and expanding the entities. The class sends
 * the unicode text encoded in UTF-8 to an opipestream specified during
 * construction and posts the changes done to the input to a cutout queue so
 * that the XML and entities may be reconstructed on output. */
class TextCleaner
{

public:
  TextCleaner(/* The pipestream to which the cleaned text in UTF-8 is sent;
                 the pipestream is closed after processing all of the input */
              pipes::opipestream *output_stream_p,
              /* The name of the input encoding */
              std::string const &input_encoding,
              /* Whether XML tags should be removed from the input for the
                 duration of the processing and then reinserted. */
              bool hide_xml,
              /* Whether entities should be expanded for the duration of the
                 processing. */
              bool expand_entities,
              /* Whether entities, which are expanded by the TextCleaner,
                 should be kept expanded permanently. */
              bool keep_entities_expanded = false,
              /* An optional queue for communicating destructive operations
                 such as XML removal or entity expansion to the output
                 formatter so they can be undone later. */
              tbb::concurrent_bounded_queue<cutout_t> *cutout_queue_p = NULL):
    m_output_stream_p(output_stream_p),
    m_input_encoding(input_encoding),
    m_hide_xml(hide_xml),
    m_expand_entities(expand_entities),
    m_keep_entities_expanded(keep_entities_expanded),
    m_cutout_queue_p(cutout_queue_p)
  {
    if (m_expand_entities)
      prepare_entity_map();
  }

  // setup changes the input stream when another file is to be processed.
  void setup(std::istream *input_stream_p) {
    m_input_stream_p = input_stream_p;
  }

  // do_word reads everything from the input stream and writes the cleaned
  // vesion to the output stream.
  void do_work();

private:
  void prepare_entity_map();
  bool expand_entity(std::string const &entity, uint32_t &expanded_str);

  pipes::opipestream *m_output_stream_p;
  std::string m_input_encoding;
  bool m_expand_entities, m_keep_entities_expanded, m_hide_xml;
  tbb::concurrent_bounded_queue<cutout_t> *m_cutout_queue_p;
  boost::unordered_map<std::string, uint32_t> m_entity_map;

  std::istream *m_input_stream_p;
};
}

#endif
