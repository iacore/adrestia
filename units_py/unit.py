import attr

from unit_kind import UnitKind

@attr.s
class Unit:
    kind: UnitKind = attr.ib()
    health: int    = attr.ib()

    @staticmethod
    def of_kind(kind: UnitKind) -> 'Unit':
        return Unit(kind, kind.health)

    def to_string_hum(self) -> str:
        return '({} (width {}) (hp {}/{}){})'.format(
                self.kind.name,
                self.kind.width,
                self.health,
                self.kind.health,
                ' (attack {})'.format(self.kind.attack) if len(self.kind.attack) > 0 else '')
