import { useBackend } from '../../backend';
import { Box, Button, Section, Table } from '../../components';
import { decodeHtmlEntities } from 'common/string';
import { COLORS } from '../../constants';

const deptCols = COLORS.department;

const HeadRoles = [
  'Captain',
  'Head of Security',
  'Chief Engineer',
  'Chief Medical Officer',
  'Research Director',
  'Head of Personnel',
];

const HCC = (role) => {
  if (HeadRoles.indexOf(role) !== -1) {
    return 'olivedrab';
  }
  return 'orange';
};

const HBC = (role) => {
  if (HeadRoles.indexOf(role) !== -1) {
    return true;
  }
};

const ManifestTable = (props, context) => {
  const { act } = useBackend(context);

  const { group } = props;

  return (
    group.length > 0 && (
      <Table>
        <Table.Row header color="white">
          <Table.Cell width="10%" />
          <Table.Cell width="35%">Name</Table.Cell>
          <Table.Cell width="35%">Rank</Table.Cell>
          <Table.Cell width="20%">Active</Table.Cell>
        </Table.Row>

        {group.map((person, i) => (
          <Table.Row
            color={HCC(person.rank)}
            key={person.name + person.rank}
            backgroundColor={i % 2 !== 0 && 'rgba(255, 255, 255, 0.05)'}>
            <Table.Cell>
              <Button
                icon="envelope"
                onClick={() => act('Message', { name: person.name })}
              />
              <Button
                icon="dollar-sign"
                onClick={() => act('Send Money', { name: person.name })}
              />
            </Table.Cell>
            <Table.Cell bold={HBC(person.rank)}>
              {decodeHtmlEntities(person.name)}
            </Table.Cell>
            <Table.Cell bold={HBC(person.rank)}>
              {decodeHtmlEntities(person.rank)}
            </Table.Cell>
            <Table.Cell bold={HBC(person.rank)}>{person.active}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )
  );
};

export const pda_manifest = (props, context) => {
  const { act, data } = useBackend(context);

  const { manifest } = data;

  const { heads, sec, eng, med, sci, civ, bot, misc } = manifest;

  return (
    <Box>
      <Section
        title={
          <Box backgroundColor={deptCols.command} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Command
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={heads} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.security} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Security
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={sec} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.engineering} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Engineering
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={eng} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.medical} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Medical
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={med} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.science} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Science
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={sci} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.service} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Service
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={civ} />
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.centcom} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Silicon
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={bot} />
      </Section>

      <Section
        title={
          <Box m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.2}>
              Misc
            </Box>
          </Box>
        }
        level={2}>
        <ManifestTable group={misc} />
      </Section>
    </Box>
  );
};
