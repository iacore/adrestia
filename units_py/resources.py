import attr

@attr.s
class Resources:
    red: int   = attr.ib(default = 0)
    green: int = attr.ib(default = 0)
    blue: int  = attr.ib(default = 0)

    @staticmethod
    def of_string_exn(s: str) -> 'Resources':
        red, green, blue = map(int, s.split(' '))
        return Resources(red=red, green=green, blue=blue)
    
    def to_string_hum(self) -> str:
        return '((red {}) (green {}) (blue {})'.format(self.red, self.green, self.blue)
    
    def subsumes(self, other: 'Resources') -> bool:
        return self.red >= other.red and self.green >= other.green and self.blue >= other.blue

    def add(self, other: 'Resources') -> None:
        self.red += other.red
        self.green += other.green
        self.blue += other.blue

    def subtract(self, other: 'Resources') -> None:
        self.red -= other.red
        self.green -= other.green
        self.blue -= other.blue
