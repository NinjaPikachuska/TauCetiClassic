import { useBackend, useLocalState } from '../../backend';
import { createSearch } from 'common/string';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Tabs,
  Table,
  Stack,
  Tooltip,
  NumberInput,
} from '../../components';

export const pda_nanobank = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    logged_in,
    owner_name,
    money,
    has_account,
    salary,
    owner_account_number,
  } = data;

  if (!logged_in || !has_account) {
    return <LoginScreen />;
  }

  return (
    <>
      <Box>
        <LabeledList>
          <LabeledList.Item label="Owner Name">{owner_name}</LabeledList.Item>
          <LabeledList.Item label="Account Number">
            {owner_account_number}
          </LabeledList.Item>
          <LabeledList.Item label="Balance">${money}</LabeledList.Item>
          <LabeledList.Item label="Salary">${salary}</LabeledList.Item>
        </LabeledList>
      </Box>
      <Box>
        <NanoBankNavigation />
        <NanoBankTabContent />
      </Box>
    </>
  );
};

const NanoBankNavigation = (properties, context) => {
  const { data } = useBackend(context);

  const { is_head } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);

  return (
    <Tabs mt={2}>
      <Tabs.Tab selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
        <Icon mr={1} name="list" />
        Transfers
      </Tabs.Tab>
      {!!is_head && (
        <Tabs.Tab selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
          <Icon mr={1} name="list" />
          Head Options
        </Tabs.Tab>
      )}
      <Tabs.Tab selected={3 === tabIndex} onClick={() => setTabIndex(3)}>
        <Icon mr={1} name="list" />
        Account Actions
      </Tabs.Tab>
      <Tabs.Tab selected={4 === tabIndex} onClick={() => setTabIndex(4)}>
        <Icon mr={1} name="list" />
        Transaction History
      </Tabs.Tab>
    </Tabs>
  );
};

const NanoBankTabContent = (props, context) => {
  const [tabIndex] = useLocalState(context, 'tabIndex', 1);

  switch (tabIndex) {
    case 1:
      return <Transfer />;
    case 2:
      return <HeadOptions />;
    case 3:
      return <AccountActions />;
    case 4:
      return <Transactions />;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const Transfer = (props, context) => {
  const { act, data } = useBackend(context);

  const { available_accounts, money } = data;

  const [selectedAccount, setSelectedAccount] = useLocalState(
    context,
    'selectedAccount',
    ''
  );

  const [transferComment, setTransferComment] = useLocalState(
    context,
    'transferComment',
    ''
  );

  const [manualEnteredAccount, setManualEnteredAccount] = useLocalState(
    context,
    'manualEnteredAccount',
    ''
  );

  const [searchTransferTerm, setSearchTransferTerm] = useLocalState(
    context,
    'searchTransferTerm',
    ''
  );

  const [manualEntry, setManualEntry] = useLocalState(
    context,
    'manualEntry',
    false
  );

  const [transferAmount, setTransferAmount] = useLocalState(
    context,
    'transferAmount',
    0
  );

  let accountNameMap = [];
  available_accounts.map(
    (account) => (accountNameMap[account.ref] = account.name)
  );

  let accountNumMap = [];
  available_accounts.map(
    (account) => (accountNumMap[account.ref] = account.account_number)
  );

  const transferAccount = manualEntry
    ? manualEnteredAccount
    : accountNumMap[selectedAccount];

  const searcher = createSearch(searchTransferTerm, (account) => account.name);

  const accounts = available_accounts.filter(searcher);

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Account">
          {manualEntry ? (
            <Input
              placeholder="Account Number"
              value={manualEnteredAccount}
              onInput={(e, value) => setManualEnteredAccount(value)}
            />
          ) : selectedAccount ? (
            `${accountNameMap[selectedAccount]}, ${accountNumMap[selectedAccount]}`
          ) : (
            '-------'
          )}
          <Button
            ml={1}
            icon="search"
            tooltip="Manual Account Number Entry"
            selected={manualEntry}
            onClick={() => setManualEntry(!manualEntry)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Amount">
          <NumberInput
            value={transferAmount}
            minValue={0}
            width="10%"
            onChange={(e, value) => setTransferAmount(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Comment">
          <Input
            value={transferComment}
            onInput={(e, value) => setTransferComment(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button.Confirm
            bold
            icon="paper-plane"
            width="auto"
            disabled={
              money < transferAmount ||
              !transferAmount ||
              transferAmount <= 0 ||
              !transferAccount
            }
            content="Send"
            onClick={() => {
              act('transfer', {
                amount: transferAmount,
                account_number: transferAccount,
                comment: transferComment,
              });
              setTransferAmount(0);
              setManualEnteredAccount('');
              setTransferComment('');
              setSelectedAccount('');
            }}
          />
        </LabeledList.Item>
      </LabeledList>
      <Box mt={3} color="label">
        Search:{' '}
        <Input
          value={searchTransferTerm}
          onInput={(e, value) => setSearchTransferTerm(value)}
        />
      </Box>
      <Section title="Accounts">
        {accounts.length ? (
          <>
            {accounts.map((account, i) => (
              <Stack key={i} m={0.5}>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="dollar-sign"
                    content={`${account.name} (${account.account_number})`}
                    selected={account.ref === selectedAccount && !manualEntry}
                    disabled={manualEntry}
                    onClick={() => setSelectedAccount(account.ref)}
                  />
                </Stack.Item>
              </Stack>
            ))}
          </>
        ) : (
          <Box>No accounts available.</Box>
        )}
      </Section>
    </Box>
  );
};

const HeadOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    subordinate_staff,
    changable_insurances,
    id_insurance_access,
    cartridge_insurance_access,
    is_insurance_price_change_on_cooldown,
    insurance_price_change_cooldown,
    insurance_price_change_default_cooldown,
    max_insurance_price,
  } = data;

  const [insurancesToSend, setInsurancesToSend] = useLocalState(
    context,
    'insurancesToSend',
    {}
  );

  return (
    <Box>
      {(!!cartridge_insurance_access || !!id_insurance_access) && (
        <Section title="Insurance Prices">
          {(!cartridge_insurance_access && (
            <Box>Insert your cartridge with access to insurance.</Box>
          )) ||
            (!id_insurance_access && (
              <Box>Insert your ID card with access to insurance.</Box>
            )) || (
              <LabeledList>
                {changable_insurances.map((insurance, i) => (
                  <LabeledList.Item key={i} label={insurance.name}>
                    <NumberInput
                      value={
                        insurancesToSend[insurance.name]
                          ? insurancesToSend[insurance.name]
                          : 0
                      }
                      width="10%"
                      minValue={0}
                      maxValue={max_insurance_price}
                      onChange={(e, value) =>
                        setInsurancesToSend({
                          ...insurancesToSend,
                          [insurance.name]: value,
                        })
                      }
                    />
                    <Box inline>(Current: {insurance.price})</Box>
                  </LabeledList.Item>
                ))}
                <LabeledList.Item>
                  <Button.Confirm
                    content="Change"
                    icon="arrow-right"
                    confirmIcon="arrow-right"
                    disabled={is_insurance_price_change_on_cooldown}
                    onClick={() =>
                      act('change_insurance_price', {
                        insurances: insurancesToSend,
                      })
                    }
                  />
                  {(!!is_insurance_price_change_on_cooldown && (
                    <Box inline color="red">
                      {insurance_price_change_cooldown}
                      <Icon name="clock" />
                    </Box>
                  )) || (
                    <Box inline>
                      {insurance_price_change_default_cooldown}
                      <Icon name="clock" />
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            )}
        </Section>
      )}
      <Section title="Salary Manager">
        {subordinate_staff.length ? (
          <>
            {subordinate_staff.map((account, i) => (
              <Stack key={i} m={0.5}>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="dollar-sign"
                    content={`${account.name} (${account.rank}) ${account.salary}$`}
                    onClick={() =>
                      act('change_salary', { account: account.account })
                    }
                  />
                </Stack.Item>
              </Stack>
            ))}
          </>
        ) : (
          <Box>No accounts available.</Box>
        )}
      </Section>
    </Box>
  );
};

const AccountActions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    money,
    security_level,
    owner_insurance_type,
    owner_insurance_price,
    owner_preferred_insurance_type,
    owner_max_insurance_payment,
    insurances,
    max_insurance_price,
  } = data;

  return (
    <LabeledList>
      <LabeledList.Item label="Account Security">
        <Button
          icon="user-lock"
          selected={security_level === 0}
          content="None"
          tooltip="To access this account, either an account number or a card is required. EFTPOS transactions will require a card and ask for a PIN, but not verify the pin is correct."
          onClick={() =>
            act('set_security', {
              new_security_level: 0,
            })
          }
        />
        <Button
          icon="user-lock"
          selected={security_level === 1}
          content="Standard"
          tooltip="In addition to account number or card, a PIN must be manually entered to access this account and process transactions."
          onClick={() =>
            act('set_security', {
              new_security_level: 1,
            })
          }
        />
        <Button
          icon="user-lock"
          selected={security_level === 2}
          content="Maximum"
          tooltip="The account number, PIN and card are required to access this account and process transactions."
          onClick={() =>
            act('set_security', {
              new_security_level: 2,
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Logout">
        <Button
          icon="sign-out-alt"
          color="red"
          width="auto"
          content="Logout"
          onClick={() => act('unlink')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Current Insurance">
        {owner_insurance_type} ({owner_insurance_price}$)
      </LabeledList.Item>
      <LabeledList.Item label="Preferred Insurance">
        {insurances.map((insurance, i) => (
          <Button
            key={i}
            selected={insurance.name === owner_preferred_insurance_type}
            content={`${insurance.name} (${insurance.price}$)`}
            onClick={() =>
              act('change_preferred_insurance', { insurance: insurance.name })
            }
          />
        ))}
      </LabeledList.Item>
      <LabeledList.Item label="Change Insurance">
        {insurances.map((insurance, i) => (
          <Button
            key={i}
            disabled={
              insurance.name === owner_insurance_type ||
              insurance.price_with_time_addition > money
            }
            content={`${insurance.name} (${insurance.price_with_time_addition}$)`}
            onClick={() =>
              act('change_insurance_immediately', { insurance: insurance.name })
            }
          />
        ))}
        <br />
        <Box color="gray" fontSize={0.8} italic>
          (An additional 10$ for every remaining minute before payday)
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Max Insurance Price">
        <NumberInput
          value={owner_max_insurance_payment}
          width="10%"
          minValue={0}
          maxValue={max_insurance_price}
          onChange={(e, value) =>
            act('change_max_insurance_payment', {
              max_insurance_payment: value,
            })
          }
        />
        <Tooltip content="If the preferred insurance becomes more expensive than this number, then a cheaper insurance will be chosen for you.">
          <Box color="gray" inline>
            (?)
          </Box>
        </Tooltip>
      </LabeledList.Item>
    </LabeledList>
  );
};

const Transactions = (props, context) => {
  const { act, data } = useBackend(context);
  const { transaction_log } = data;

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Time</Table.Cell>
        <Table.Cell>Purpose</Table.Cell>
        <Table.Cell>Value</Table.Cell>
        <Table.Cell>From/To</Table.Cell>
        <Table.Cell>Terminal</Table.Cell>
      </Table.Row>
      {transaction_log.map((t, i) => (
        <Table.Row
          key={t}
          backgroundColor={i % 2 !== 0 && 'rgba(255, 255, 255, 0.05)'}>
          <Table.Cell>{t.time}</Table.Cell>
          <Table.Cell>{t.purpose}</Table.Cell>
          <Table.Cell color={t.is_deposit ? 'green' : 'red'}>
            ${t.amount}
          </Table.Cell>
          <Table.Cell>{t.target_name}</Table.Cell>
          <Table.Cell>{t.terminal}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const LoginScreen = (props, context) => {
  const { act, data } = useBackend(context);

  const [accountID, setAccountID] = useLocalState(context, 'accountID', null);

  const [accountPin, setAccountPin] = useLocalState(
    context,
    'accountPin',
    null
  );

  const { has_account, has_id, id_name, login_fail_reason, owner_name } = data;

  if (has_account) {
    return (
      <>
        <Box bold pb={2}>
          Welcome back, {owner_name}!
        </Box>
        <LabeledList>
          <LabeledList.Item label="ID card">
            <Button
              icon="id-card"
              selected={has_id}
              onClick={() => act('switch_id')}
              content={has_id ? id_name : 'No ID Inserted'}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Account PIN">
            <Input
              value={accountPin}
              placeholder="Account Pin"
              onInput={(e, value) => setAccountPin(value)}
            />
          </LabeledList.Item>
          {login_fail_reason && (
            <LabeledList.Item>
              <Box color="red" bold>
                {login_fail_reason}
              </Box>
            </LabeledList.Item>
          )}
          <LabeledList.Item>
            <Button
              content="Login"
              icon="sign-in-alt"
              onClick={() =>
                act('login', {
                  account_pin: accountPin,
                })
              }
            />
            <Button
              content="Logout"
              icon="sign-in-alt"
              color="red"
              onClick={() => act('unlink')}
            />
          </LabeledList.Item>
        </LabeledList>
      </>
    );
  } else {
    return (
      <LabeledList>
        <LabeledList.Item label="ID card">
          <Button
            icon="id-card"
            selected={has_id}
            onClick={() => act('switch_id')}
            content={has_id ? id_name : 'No ID Inserted'}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Account ID">
          <Input
            value={accountID}
            placeholder="Account ID"
            onInput={(e, value) => setAccountID(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pin">
          <Input
            value={accountPin}
            placeholder="Account Pin"
            onInput={(e, value) => setAccountPin(value)}
          />
        </LabeledList.Item>
        {login_fail_reason && (
          <LabeledList.Item>
            <Box color="red" bold>
              {login_fail_reason}
            </Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item>
          <Button
            content="Login"
            icon="sign-in-alt"
            onClick={() =>
              act('link_account', {
                account_num: accountID,
                account_pin: accountPin,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    );
  }
};
