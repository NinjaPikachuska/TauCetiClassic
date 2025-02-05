import { useBackend, useLocalState } from '../../backend';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
} from '../../components';

export const pda_messenger = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_chat } = data;

  if (Object.keys(current_chat).length) {
    return <ActiveConversation data={data} />;
  }
  return <MessengerList data={data} />;
};

const ActiveConversation = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const { current_chat } = data;

  const messages = current_chat.messages;

  const [messageTexts, setMessageTexts] = useLocalState(
    context,
    'messageTexts',
    {}
  );

  return (
    <Stack fill vertical>
      <Stack.Item mb={0.5}>
        <LabeledList>
          <LabeledList.Item label="Messenger">
            <Button.Confirm
              content="Delete Conversation"
              confirmContent="Are you sure?"
              icon="trash"
              confirmIcon="trash"
              color="bad"
              onClick={() => act('Clear', { option: 'Convo' })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Section
        fill
        scrollable
        title={'Conversation with ' + current_chat.name + ' (' + current_chat.job + ')'}
      >
        {messages.map((message, i) => (
          <Box
            textAlign={message.outgoing ? 'right' : 'left'}
            position="relative"
            mb={1}
            key={i}
          >
            <Icon
              fontSize={2.5}
              color={message.outgoing ? '#4d9121' : '#cd7a0d'}
              position="absolute"
              left={message.outgoing ? null : '0px'}
              right={message.outgoing ? '0px' : null}
              bottom="-4px"
              style={{
                'z-index': '0',
                'transform': message.outgoing ? 'scale(-1, 1)' : null,
              }}
              name="comment"
            />
            <Box
              inline
              backgroundColor={message.outgoing ? '#4d9121' : '#cd7a0d'}
              p={1}
              maxWidth="100%"
              position="relative"
              textAlign="left"
              style={{
                'z-index': '1',
                'border-radius': '10px',
                'word-wrap': 'break-word',
              }}
            >
              {message.outgoing ? 'You:' : 'Them:'} {message.message}
              <Box
                textAlign="right"
                italic
                color="lightgray"
                fontSize="10px"
              >
                {message.timestamp}
              </Box>
            </Box>
          </Box>
        ))}
      </Section>
      <Stack.Item>
        <Stack fill align="center">
          {!!current_chat.can_reply && (
            <>
              <Stack.Item grow={1}>
                <Input
                  value={messageTexts[current_chat.ref]}
                  autoFocus
                  width="100%"
                  maxLength={1024}
                  onInput={(e, value) => setMessageTexts({ ...messageTexts, [current_chat.ref]: value })}
                  onEnter={(e, value) => {
                    act('Message', { message: value });
                    setMessageTexts({ ...messageTexts, [current_chat.ref]: "" });
                  }}
                />
              </Stack.Item>
              <Button
                icon="arrow-right"
                onClick={() => {
                  act('Message', { message: messageTexts[current_chat.ref] });
                  setMessageTexts({ ...messageTexts, [current_chat.ref]: "" });
                }}
              />
            </>
          ) || (
            <Stack.Item grow={1}
              color="red"
              textAlign="center"
              bold
              fontSize="16px"
            >
              User is not available.
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};



const MessengerList = (props, context) => {
  const { act } = useBackend(context);

  const data = props.data;

  const [searchTerm, setSearchTerm] = useLocalState(
    context,
    "searchTerm",
    ""
  );

  const { last_chats, available_chats, charges, silent, toff, ringtone_list, ringtone, searchTarget }
    = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Messenger">
            <Button
              selected={!silent}
              icon={silent ? 'volume-mute' : 'volume-up'}
              onClick={() => act('Toggle Ringer')}
            >
              Ringer: {silent ? 'Off' : 'On'}
            </Button>
            <Button
              color={toff ? 'bad' : 'green'}
              icon="power-off"
              onClick={() => act('Toggle Messenger')}
            >
              Messenger: {toff ? 'Off' : 'On'}
            </Button>
            <br />
            <Button.Confirm
              content="Delete All Conversations"
              confirmContent="Are you sure?"
              icon="trash"
              confirmIcon="trash"
              color="bad"
              onClick={() => act('Clear', { option: 'All' })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Ringtones">
            <Button icon="bell" onClick={() => act('Ringtone')}>
              Set Custom Ringtone
            </Button>
            <br />
            <Dropdown
              selected={ringtone}
              width="145px"
              options={Object.keys(ringtone_list)}
              onSelected={(value) =>
                act('Available_Ringtones', { selected_ringtone: value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Box>
        {!!charges && (
          <Box mt={2}>
            <LabeledList>
              <LabeledList.Item label="Cartridge Special Function">
                {charges} charges left.
              </LabeledList.Item>
            </LabeledList>
          </Box>
        )}
        <Box mt={2} color="label">
          Search:{' '}
          {searchTarget ? (
            <Box inline bold color="white">
              {searchTarget}
              <Button
                ml={1}
                icon="trash"
                color="red"
                onClick={() => act('Search Target Clear')}
              />
            </Box>
          ) : (
            <Input
              value={searchTerm}
              onInput={(e, value) => setSearchTerm(value)}
            />
          )}
        </Box>
      </Box>
      <PDAList
        title="Last Conversations"
        data={data}
        chats={last_chats}
        chatAct={"Select Chat"}
        searchTerm={searchTarget ? searchTarget : searchTerm}
      />
      <PDAList
        title="All Conversations"
        chats={available_chats}
        chatAct={"Create Chat"}
        data={data}
        searchTerm={searchTarget ? searchTarget : searchTerm}
      />
    </Stack>
  );
};

const PDAList = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const { chats, title, searchTerm, chatAct } = props;

  const { charges, plugins } = data;

  const searcher = createSearch(searchTerm, (messenger) => messenger.name);

  const chatsAvailable = flow([
    filter(searcher),
    sortBy(messenger => messenger.name),
    sortBy(messenger => !messenger.has_unread),
  ])(chats);

  if (!chatsAvailable.length) {
    return <Section title={title}>No conversations found.</Section>;
  }

  return (
    <Section fill scrollable title={title}>
      {chatsAvailable.map((messenger, i) => (
        <Stack key={i} m={0.5}>
          <Stack.Item grow>
            <Button
              fluid
              icon="comment"
              iconColor={!!messenger.has_unread && "white"}
              color={!!messenger.has_unread && "red"}
              content={`${messenger.name} (${messenger.job})`}
              onClick={() => act(chatAct, { target: messenger.ref })}
            />
          </Stack.Item>
          <Stack.Item>
            {!!charges
              && plugins.map((plugin) => (
                <Button
                  key={plugin.ref}
                  icon={plugin.icon}
                  content={plugin.name}
                  onClick={() =>
                    act('Messenger Plugin', {
                      plugin: plugin.ref,
                      target: messenger.ref,
                    })}
                />
              ))}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
